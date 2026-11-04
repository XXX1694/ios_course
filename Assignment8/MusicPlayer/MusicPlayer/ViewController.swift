//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Abzal Serikbay on 21.11.2026.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!

    let tracks = TrackLibrary.tracks
    var currentIndex = 0
    var isPlaying = false
    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTrack()
        updateScreen()
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
        loadTrack()
        updateScreen()
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        isPlaying.toggle()
        if isPlaying {
            player?.play()
        } else {
            player?.pause()
        }
        updateScreen()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        showNextTrack()
    }

    func showNextTrack() {
        currentIndex = (currentIndex + 1) % tracks.count
        loadTrack()
        updateScreen()
    }

    func loadTrack() {
        let track = tracks[currentIndex]
        player?.stop()
        player = nil

        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "mp3") else {
            print("Audio file not found: \(track.fileName).mp3")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            if isPlaying {
                player?.play()
            }
        } catch {
            print("Could not play \(track.fileName).mp3: \(error.localizedDescription)")
        }
    }

    func updateScreen() {
        let track = tracks[currentIndex]
        coverImageView.image = UIImage(named: track.coverImageName)
        titleLabel.text = track.title
        artistLabel.text = track.artist
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = true
        showNextTrack()
    }

}
